# Simple test image
FROM public.ecr.aws/docker/library/alpine:3.20

ARG EXAMPLE_ARG
ENV EXAMPLE_ARG=${EXAMPLE_ARG}

# Just for demo
RUN echo "Hello from docker-bake test image"

CMD sh -c "echo 'Container started from docker-bake test image showing ${EXAMPLE_ARG}' && uname -a && sleep 10"
