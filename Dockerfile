FROM pandoc/extra:latest

# Customize the shell prompt.
ARG USER_COLOR="\e[94m"
ARG PWD_COLOR="\e[92m\e[1m"
ARG PROMPT_CHAR_COLOR="\e[95m"
# Sometimes the "\$" escape sequence doesn't reflect whether the user is actually root. The next line fixes that.
ENV PROMPT_CHAR='$( [ "$(id -u)" -eq 0 ] && echo "#" || echo "$" )'
RUN echo "export PS1='${USER_COLOR}\u:\033[0m${PWD_COLOR}\w\033[0m ${PROMPT_CHAR_COLOR}${PROMPT_CHAR}\033[0m '" > /usr/profile
ENV ENV=/usr/profile

# Install dependencies
RUN tlmgr install newtx xstring fontaxes mathtools siunitx mhchem physics
RUN tlmgr install framed tex-gyre
# RUN tlmgr install skylighting
RUN apk update
RUN apk add typst
# RUN apk add font-dejavu
RUN apk add fontconfig
RUN fc-cache -fv
# RUN apk update
# RUN apk add pandoc

WORKDIR /app

# Create a non-root user
RUN adduser -D user

# Make the build directory and give it to the defined user
RUN mkdir build && chown -R user ./build

# Set up fonts
COPY fonts /usr/share/fonts

# Set up build script
COPY build.sh ./build.sh
RUN chmod +x ./build.sh

COPY src ./src

# Activate the user
# USER user

ENTRYPOINT ["./build.sh"]