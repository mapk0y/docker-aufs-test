FROM debian
MAINTAINER mapk0y@gmail.com

COPY ./sample.sh /sample.sh
RUN chmod +x /sample.sh && /sample.sh
