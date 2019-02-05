FROM google/dart
ENV PATH="$PATH":"/root/.pub-cache/bin"
RUN pub global activate webdev
