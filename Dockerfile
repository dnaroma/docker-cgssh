FROM ficusio/openresty:latest

# Install letsencrypt, code forked from https://github.com/xataz/dockerfiles/blob/master/letsencrypt/Dockerfile
# replace letsencrypt-auto with acme-tiny

WORKDIR /acme-tiny
ENV PATH /acme-tiny/venv/bin:$PATH

RUN export BUILD_DEPS="git \
                build-base \
                libffi-dev \
                linux-headers \
                openssl-dev \
                py-pip \
                python-dev" \
    && apk add -U dialog \
                python \
                augeas-libs \
                openssl \
                ${BUILD_DEPS}
RUN pip --no-cache-dir install virtualenv
RUN git clone https://github.com/diafygi/acme-tiny.git /acme-tiny
RUN virtualenv --no-site-packages -p python2 /acme-tiny/venv
RUN /acme-tiny/venv/bin/pip install -r /acme-tiny/tests/requirements.txt
RUN apk del ${BUILD_DEPS} \
    && rm -rf /var/cache/apk/*

# Set certificate, see https://github.com/diafygi/acme-tiny

WORKDIR /acme-tiny
# Create a Let's Encrypt account private key
RUN openssl genrsa 4096 > account.key
# Create a certificate signing request (CSR) for your domains
# for multiple domains (use this one if you want both www.yoursite.com and yoursite.com)
RUN openssl req -new -sha256 -key domain.key -subj "/" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:ilovelive.tk,DNS:www.ilovelive.tk")) > domain.csr
# Get a signed certificate! (make sure nginx correctly configured)
RUN mkdir -p /var/www/challenges/ \
    && python acme_tiny.py --account-key ./account.key --csr ./domain.csr --acme-dir /var/www/challenges/ > ./signed.crt

EXPOSE 80 443
