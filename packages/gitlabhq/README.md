To update the pip packages:

``` bash
cd /path/to/release
mkdir -p blobs/python-pip-gitlabhq
for package in pygments
do
  pip install -d blobs/python-pip-gitlabhq ${package}
done
echo Package files to include in spec:
for file in $(ls -t blobs/python-pip-gitlabhq/)
do
  echo "- python-pip-gitlabhq/${file}"
done
```