cd /home/jovyan/work

if [ ! -e models ]; then

mkdir models
cd models
wget -O duplex.zip https://portal.nibs.org/files/wl/?id=4DsTgHFQAcOXzFetxbpRCECPbbfUqpgo
unzip *.zip
rm *.zip
cd ..

fi

if [ ! -e 01_visualize.ipynb ]; then

/opt/build/py2ipynb/py2ipynb.py /opt/examples/01_visualize.py 01_visualize.ipynb

fi

if [ ! -e 02_analyze.ipynb ]; then

/opt/build/py2ipynb/py2ipynb.py /opt/examples/02_analyze.py 02_analyze.ipynb

fi

if [ ! -e ifc_viewer.py ]; then

cp /opt/examples/ifc_viewer.py ifc_viewer.py

fi
