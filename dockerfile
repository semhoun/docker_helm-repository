FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux

WORKDIR "/tmp"

COPY bin/ /opt/bin/
COPY share/ /opt/share/

RUN mkdir -p /www \
	\
	# Install base software
	&& apt-get update -y \
	&& apt-get install -y --no-install-recommends curl ca-certificates vim bash dos2unix wget git unzip locales \
	\
	# Install apache
    && apt-get install -y apache2 apache2-utils \
	\
	# Configure locales
	&& sed \
		-e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' \
		-e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' \
		-i /etc/locale.gen \
	&& /usr/sbin/locale-gen	\
	\
    # Configure Apache
	&& a2enmod deflate headers \
	&& rm /etc/apache2/apache2.conf \
	\
	# Add Helm3
	&& mkdir -p /opt/helm-share/plugins \
	&& curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash \
	&& HELM_HOME=~/.local/share/helm/ helm plugin install https://github.com/halkeye/helm-repo-html \
	\
	# Manage www-data user
	&& usermod www-data -d /www \
	\
	# Manage www directory and permissions
	&& chown -R www-data.www-data /www  \
	&& chmod +x /opt/bin/*  \
	\
	# Clean
	&& apt-get -y autoremove \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Configure Apache
COPY conf/apache/. /etc/apache2/
   
WORKDIR "/www"
VOLUME ["/www"]

STOPSIGNAL SIGWINCH

# Start Apache service
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
ENTRYPOINT ["/opt/bin/docker-entrypoint.sh"]