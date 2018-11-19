# Pre-create config manipulation

This is a proof-of-concept for [this approach][1], which is a more generic form of hook injection supported by some current orchestrators (e.g. CRI-O and Podman [here][2]).
The wrapper looks for [a `create` command][3], and, if found, flushes the original `config.json` through all the filters in the filter directory in collation order.
Then it invokes the real runtime to perform the requested operation.

For example, using `echo` as a dummy runtime and the local [`config-filters.d`](config-filters.d) as the filter directory:

```console
$ RUNTIME=echo FILTER_DIR=config-filters.d ./wrapped-runtime.sh create 123
create 123
```

You can use `git diff` to see how the original `config.json` was altered:

```diff
diff --git a/config.json b/config.json
index 4b06157..de7ac43 100644
--- a/config.json
+++ b/config.json
@@ -190,6 +190,15 @@
         "fileMode": 432,
         "uid": 0,
         "gid": 0
+      },
+      {
+        "path": "/dev/mydev",
+        "type": "c",
+        "major": 123,
+        "minor": 456,
+        "fileMode": 438,
+        "uid": 0,
+        "gid": 0
       }
     ],
     "uidMappings": [
```

This behavior allows for all sorts of changes, so make sure you trust anything that goes into the filter directory.

[1]: https://github.com/opencontainers/runc/pull/1811#issuecomment-439744444
[2]: https://github.com/containers/libpod/blob/master/pkg/hooks/docs/oci-hooks.5.md
[3]: https://github.com/opencontainers/runtime-tools/blob/v0.8.0/docs/command-line-interface.md#create
