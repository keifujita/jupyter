FROM python:3-stretch
RUN apt-get -y update && apt-get -y install less ssl-cert vim
RUN pip3 install --upgrade jupyter matplotlib seaborn numpy pandas scipy scikit-learn line_profiler memory_profiler
RUN mkdir -p /root/jupyter
RUN jupyter notebook --generate-config -y
ARG PASSWORD=DEFAULTPASSWORD
RUN make-ssl-cert generate-default-snakeoil --force-overwrite
RUN p=$(python -c "from notebook.auth import passwd; print(passwd('$PASSWORD'))") && perl -pi.original -e "s{^#c.NotebookApp.certfile = ''}{c.NotebookApp.certfile = '/etc/ssl/certs/ssl-cert-snakeoil.pem'};s{^#c.NotebookApp.ip = 'localhost'}{c.NotebookApp.ip = '*'};s{^#c.NotebookApp.keyfile = ''}{c.NotebookApp.keyfile = '/etc/ssl/private/ssl-cert-snakeoil.key'};s{^#c.NotebookApp.notebook_dir = ''}{c.NotebookApp.notebook_dir = '/root/jupyter'};s{^#c.NotebookApp.open_browser = True}{c.NotebookApp.open_browser = False};s{^#c.NotebookApp.password = ''}{c.NotebookApp.password = '$p'};" /root/.jupyter/jupyter_notebook_config.py
VOLUME ["/root/jupyter"]
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]
EXPOSE 8888
CMD ["jupyter", "notebook", "--allow-root"]
