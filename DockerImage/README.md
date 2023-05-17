
Build Docker Image
```
$docker build --build-arg GIT_ACCESS_TOKEN=[insert-access-token-here] -t [image_name]:[image_tag] .
```
Run Docker Container
```
$docker run --name [conatainer_name] -e USER=user -e PASSWORD=password -p 8787:8787 [image_name]:[image_tag]
```