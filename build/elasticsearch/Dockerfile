ARG IMAGE_TAG
FROM elasticsearch:${IMAGE_TAG}
ARG IMAGE_TAG
RUN echo "Elastic Search tag: ${IMAGE_TAG}" | tee /tmp/IMAGE_TAG

RUN bin/elasticsearch-plugin install --batch ingest-attachment

