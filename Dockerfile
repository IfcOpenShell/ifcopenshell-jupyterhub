FROM jupyterhub-user

MAINTAINER Thomas Krijnen <thomas@ifcopenshell.org>

USER root

RUN apt-get update
RUN apt-get install -y wget git cmake build-essential libgl1-mesa-dev libfreetype6-dev swig libglu1-mesa-dev libzmq3-dev libsqlite3-dev libboost-all-dev libicu-dev python3-dev

# OCE

WORKDIR /opt/build
RUN git clone https://github.com/aothms/oce
RUN mkdir oce/build && mkdir oce/install
WORKDIR /opt/build/oce/build
RUN git checkout copy_headers

ENV CFLAGS=-fPIC
ENV CXXFLAGS=-fPIC

RUN cmake \
 -DOCE_TESTING=OFF \
 -DOCE_BUILD_SHARED_LIB=ON \
 -DOCE_VISUALISATION=ON \
 -DOCE_OCAF=OFF \
 -DOCE_INSTALL_PREFIX=/opt/build/install/oce \
 ..

RUN make -j4 install

# IfcOpenShell

WORKDIR /opt/build
RUN git clone https://github.com/IfcOpenShell/IfcOpenShell
WORKDIR IfcOpenShell/build
RUN git checkout v0.6.0
ADD https://api.github.com/repos/IfcOpenShell/IfcOpenShell/git/refs/heads/v0.6.0 /tmp/ifcopenshell_version.json
RUN git pull

RUN cmake \
 -DCOLLADA_SUPPORT=Off \
 -DBUILD_EXAMPLES=Off \
 -DIFCXML_SUPPORT=Off \
 -DOCC_INCLUDE_DIR=/opt/build/install/oce/include/oce \
 -DOCC_LIBRARY_DIR=/opt/build/install/oce/lib \
 -DPYTHON_LIBRARY=/opt/conda/lib/libpython3.6m.so \
 -DPYTHON_INCLUDE_DIR=/opt/conda/include/python3.6m \
 -DPYTHON_EXECUTABLE=/opt/conda/bin/python \
 ../cmake
 
RUN make -j4 install

# pyOCC

WORKDIR /opt/build
RUN git clone https://github.com/aothms/pythonocc-core
WORKDIR /opt/build/pythonocc-core/build
RUN git checkout review/jupyter_render_improvements

RUN cmake \
 -DOCE_INCLUDE_PATH=/opt/build/install/oce/include/oce \
 -DOCE_LIB_PATH=/opt/build/install/oce/lib \
 -DPYTHONOCC_WRAP_VISU=ON \
 -DPYTHONOCC_WRAP_OCAF=OFF \
 -DPYTHON_LIBRARY=/opt/conda/lib/libpython3.6m.so \
 -DPYTHON_INCLUDE_DIR=/opt/conda/include/python3.6m \
 -DPYTHON_EXECUTABLE=/opt/conda/bin/python \
 ..
 
RUN make -j4 install

RUN echo "/opt/build/install/oce/lib" >> /etc/ld.so.conf.d/pyocc.conf
RUN ldconfig

RUN conda install -y matplotlib
RUN conda install -y -c conda-forge ipywidgets

# pythreejs

WORKDIR /opt/build
RUN git clone https://github.com/aothms/pythreejs
WORKDIR /opt/build/pythreejs
RUN git checkout own_fixes
RUN chown -R jovyan .
USER jovyan
RUN /opt/conda/bin/pip install --user -e .
WORKDIR /opt/build/pythreejs/js
RUN npm run autogen
RUN npm run build:all
USER root
RUN jupyter nbextension install --py --symlink --sys-prefix pythreejs
RUN jupyter nbextension enable pythreejs --py --sys-prefix

# populate workspace with examples

WORKDIR /opt/build
COPY examples/populate_workspace.sh /opt/build/populate_workspace.sh
RUN chmod +x /opt/build/populate_workspace.sh
RUN sed -e '38i/opt/build/populate_workspace.sh' -i /usr/local/bin/start-singleuser.sh
RUN git clone https://github.com/gatsoulis/py2ipynb
COPY examples/01_visualize.py /opt/examples/01_visualize.py
COPY examples/02_analyze.py /opt/examples/02_analyze.py
COPY examples/ifc_viewer.py /opt/examples/ifc_viewer.py

# viewer optimizations

# USER jovyan
# RUN /opt/conda/bin/pip install --user --upgrade --pre pyzmq
# USER root
# # COPY optimize_traitlets.py /home/jovyan/.local/lib/python3.6/site-packages/optimize_traitlets.py
# WORKDIR /opt/build
# RUN git clone https://github.com/vidartf/ipytunnel
# WORKDIR ipytunnel
# RUN chown -R jovyan .
# USER jovyan
# RUN /opt/conda/bin/pip install --user -e .
# USER root
# RUN jupyter nbextension enable --py --sys-prefix ipytunnel

USER jovyan
WORKDIR /home/jovyan/work
