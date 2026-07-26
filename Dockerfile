FROM filebrowser/filebrowser:v2.63.21

# The stock image creates an admin/admin account on first boot and leaves it at
# that. This entrypoint sets the password from the environment instead, and
# refuses to start if one was not supplied.
COPY entrypoint.sh /entrypoint.sh
USER root
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
