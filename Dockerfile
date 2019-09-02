FROM node:latest

RUN mkdir -p /home/puppeteer
WORKDIR /home/puppeteer
RUN apt update ; \
    apt -y install lsb-release apt-transport-https ca-certificates ; \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg ; \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php7.3.list ; \
    apt update ; apt install -y \
      curl \
      git \
      php7.3-cli \
      php-mbstring \
      unzip \
    ; \
    rm -rf /var/lib/apt/lists/* ; \
    curl -sS https://getcomposer.org/installer -o composer-setup.php ; \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer ; \
    rm composer-setup.php

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r puppeteer && useradd -r -g puppeteer -G audio,video puppeteer \
    && mkdir -p /home/puppeteer/Downloads \
    && chown -R puppeteer:puppeteer /home/puppeteer 

USER puppeteer    

RUN composer require nesk/puphpeteer ; \
    npm install @nesk/puphpeteer ; \
    composer require guzzlehttp/guzzle:~6.0