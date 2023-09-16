# Tiny Tools with manifest list for multiple architectures (amd64,arm64)

Based on Alpine. Includes: curl, dig, nc, jq, ntpdate, mutt, ssmtp

Image Size: ~15Mb

```bash
docker run -ti fabianlee/tiny-tools-multi-arch sh
```

# Creating tag that invokes Github Action

```
newtag=v1.0.1
git commit -a -m "changes for new tag $newtag" && git push
git tag $newtag && git push origin $newtag
```

# Deleting tag

```
# delete local tag, then remote
todel=v1.0.1
git tag -d $todel && git push origin :refs/tags/$todel
```

