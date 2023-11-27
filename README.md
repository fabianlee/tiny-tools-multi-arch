# Tiny Tools with manifest list for multiple architectures (amd64,arm64)

Based on Alpine. Includes: curl, dig, nc, [jq](https://jqlang.github.io/jq/), [yq](https://github.com/mikefarah/yq), ntpdig, mutt, ssmtp, [jwker](https://github.com/jphastings/jwker), [step](https://github.com/smallstep/cli)

blog article: https://fabianlee.org/2023/09/16/docker-building-multi-platform-images-that-use-fat-manifest-list-index/

blog: https://fabianlee.org/2023/09/16/github-automated-build-and-publish-of-multi-platform-container-image-with-github-actions/

```
docker run -ti ghcr.io/fabianlee/tiny-tools-multi-arch:2.0.3 sh
```

# Creating tag that invokes Github Action

```
newtag=v1.0.1
git commit -a -m "changes for new tag $newtag" && git push -o ci.skip
git tag $newtag && git push origin $newtag
```

# Deleting tag

```
# delete local tag, then remote
todel=v1.0.1
git tag -d $todel && git push -d origin $todel
```

