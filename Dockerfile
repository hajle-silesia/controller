# Use build image that allows to match Python version between build stage and runtime stage.
# "Distroless" images usually don't support the latest Python version. Instead, they follow the version allowed by distribution they use.
# Therefore, for consistency, it's reasonable to use the same distribution in the build stage.
FROM debian:12.10 AS build
ARG WORKDIR="/project"
WORKDIR "${WORKDIR}"
ARG VENV_DIR=".venv"
ENV PATH="${WORKDIR}/${VENV_DIR}/bin:${PATH}"
# Install python3-venv for built-in Python 3 venv module (not installed by default).
# Install gcc, libpython3-dev to compile CPython modules.
RUN apt-get update && \
    apt-get install \
      --yes \
      --no-install-suggests \
      --no-install-recommends \
      python3-venv \
      gcc libpython3-dev
# Install and upgrade pip, setuptools, wheel to build and distribute Python packages.
RUN python3 -m venv "${VENV_DIR}" && \
    python3 -m pip install --upgrade pip setuptools wheel

FROM build AS build-venv
ARG REQUIREMENTS_FILE="requirements.txt"
COPY "${REQUIREMENTS_FILE}" .
RUN if [ -f "${REQUIREMENTS_FILE}" ]; then python3 -m pip install -r "${REQUIREMENTS_FILE}"; fi

FROM gcr.io/distroless/python3-debian12@sha256:224c734ca6de7cef2350e82ff9e01b4b56ce22ca3cbef3936018bfb171a7c6de AS runtime
ARG WORKDIR="/project"
WORKDIR "${WORKDIR}"
ENV PATH="${WORKDIR}/.venv/bin:${PATH}"
COPY --from=build-venv "${WORKDIR}" "${WORKDIR}"
ARG APP_DIR="src/controller"
COPY "${APP_DIR}" "${APP_DIR}"
ENTRYPOINT ["python3", "src/controller/main.py"]
