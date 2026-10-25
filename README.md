# LineageOS-priv_keys-template

# Usage

```bash
git clone https://github.com/maxxcodebug/vendor_lineage-priv_keys.git vendor/lineage-priv/keys
```
## Put this in your lineage_codename.mk
```bash
-include vendor/lineage-priv/keys/keys.mk
```
### Then

```bash
cd vendor/lineage-priv/keys
```

```
./keys.sh
```

# Testing

Included `check_keys.py` script checks whether all apk/apex/capex files in the build out are signed with keys within its directory. Be aware that some targets are **expected** to be signed with vendor key, for example `com.android.apex.cts.shim.v1_prebuilt`.

```
$ ./check_keys.py ~/voltage/out/target/product/lynx
/home/ab/voltage/out/target/product/Tetris/obj/ETC/com.android.apex.cts.shim.v1_prebuilt_intermediates/com.android.apex.cts.shim.apex is signed with an unknown key!
```
