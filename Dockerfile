FROM odoo:11.0
# switch to root user
USER root

# create directory for backups to be used by our auto_backups module by default
RUN mkdir -p /home/odoo/backups \ 
        && chown -R odoo /home/odoo/backups
# build the packages cache and install git utility and python packages needed by the manufacturing addons
RUN set -x; \
        apt-get update \
        && apt-get install -y git-core python3-tk build-essential autoconf libtool pkg-config python3-dev libsasl2-dev libldap2-dev libssl-dev
# Update PIP
RUN pip3 install --upgrade pip
#Install packages reuqired by our custom modules
RUN  pip3 install paramiko xlwt scipy matplotlib setuptools wheel pyldap qrcode vobject openpyxl xlrd
RUN apt-get install python3-dateutil
RUN apt-get install python3-babel
RUN pip3 install PyMySQL
# Branch to clone in each repository
ENV BRANCH_NAME 11.0
# change working directory
WORKDIR /mnt
#Clone odoo source code repository
RUN git ls-remote --exit-code --heads https://github.com/odoo/odoo.git ${BRANCH_NAME} \
	&& git clone --branch ${BRANCH_NAME} --depth 1 https://github.com/odoo/odoo.git source-clone \
	&& chown -R odoo source-clone
# create directory for extra or custom addons
RUN mkdir -p /mnt/source-clone/extra-addons
##############################################
# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
# copy config file from context to the desired location in the container
COPY odoo.conf /etc/odoo
# set ownership of the config file
RUN chown -R odoo /etc/odoo
# switch user to odoo
USER odoo
# Volumes
VOLUME ["/var/lib/odoo", "/mnt/source-clone", "/etc/odoo", "/var/log/odoo", "/home/odoo/backups", "/var/lib/odoo/addons/11.0"]
# Set the default config file
ENV OPENERP_SERVER /etc/odoo/odoo.conf
ENTRYPOINT ["/entrypoint.sh"]
CMD ["-c", "/etc/odoo/odoo.conf"]
