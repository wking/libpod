#!/usr/bin/env bats
#
# Tests based on 'podman help'
#
# Find all commands listed by 'podman --help'. Run each one, make sure it
# provides its own --help output. If the usage message ends in '[command]',
# treat it as a subcommand, and recurse into its own list of sub-subcommands.
#
# Any usage message that ends in '[flags]' is interpreted as a command
# that takes no further arguments; we confirm by running with 'invalid-arg'
# and confirming that it exits with error status and message.
#
load helpers

# run 'podman help', parse the output looking for 'Available Commands';
# return that list.
function podman_commands() {
    dprint "$@"
    run_podman help "$@" |\
        awk '/^Available Commands:/{ok=1;next}/^Flags:/{ok=0}ok { print $1 }' |\
        grep .
    "$output"
}


function check_help() {
    local count=0
    local subcommands_found=0

    for cmd in $(podman_commands "$@"); do
        dprint "podman $@ $cmd --help"
        run_podman "$@" $cmd --help

        # The line immediately after 'Usage:' gives us a 1-line synopsis
        usage=$(echo "$output" | grep -A1 '^Usage:' | tail -1)
        [ -n "$usage" ] || die "podman $cmd: no Usage message found"

        # If usage ends in '[command]', recurse into subcommands
        if expr "$usage" : '.*\[command\]$' >/dev/null; then
            subcommands_found=$(expr $subcommands_found + 1)
            check_help "$@" $cmd
            continue
        fi

        # If usage ends in '[flag]', command takes no more arguments.
        # Confirm that by running with 'invalid-arg' and expecting failure.
        if expr "$usage" : '.*\[flags\]$' >/dev/null; then
            if [ "$cmd" != "help" ]; then
                run_podman 125 "$@" $cmd invalid-arg
                is "$output" "Error: .* takes no arguments" \
                   "'podman $@ $cmd' with extra (invalid) arguments"
            fi
        fi

        count=$(expr $count + 1)
    done

    # This can happen if the output of --help changes, such as between
    # the old command parser and cobra.
    [ $count -gt 0 ] || \
        die "Internal error: no commands found in 'podman help $@' list"

    # At least the top level must have some subcommands
    if [ -z "$*" -a $subcommands_found -eq 0 ]; then
        die "Internal error: did not find any podman subcommands"
    fi
}


@test "podman help - basic tests" {
    # Called with no args -- start with 'podman --help'. check_help() will
    # recurse for any subcommands.
    check_help
}

# vim: filetype=sh
