FROM python AS metadata
LABEL maintainer="Stefano Pigozzi <me@steffo.eu>"

FROM metadata AS workdir
WORKDIR /usr/src/rygforms

FROM metadata AS poetry
RUN pip install "poetry"

FROM poetry AS dependencies
COPY pyproject.toml ./pyproject.toml
COPY poetry.lock ./poetry.lock
RUN poetry install --no-root --no-dev

FROM dependencies AS package
COPY . .
RUN poetry install

FROM package AS environment
ENV PYTHONUNBUFFERED=1

FROM environment AS entrypoint
ENTRYPOINT ["poetry", "run"]
CMD [ "gunicorn", "-b", "0.0.0.0:80", "rygforms.__main__:reverse_proxy_app" ]
