FROM mcp/playwright:latest

USER root

# Install X11, VNC, and process management components
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    supervisor \
    fluxbox \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

# Create directories for supervisor and logs
RUN mkdir -p /var/log/supervisor /var/run/supervisor

# Install Playwright browsers with dependencies for headed mode
# The base image may only have headless browsers
RUN npx playwright install chromium --with-deps || true

# Set display environment variable
ENV DISPLAY=:99
ENV SCREEN_WIDTH=1920
ENV SCREEN_HEIGHT=1080
ENV SCREEN_DEPTH=24
ENV MCP_PORT=3000
ENV MCP_BROWSER=chromium

# Copy configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
COPY start-mcp.sh /usr/local/bin/start-mcp.sh
COPY playwright-config.json /etc/playwright-config.json
RUN chmod +x /entrypoint.sh /usr/local/bin/start-mcp.sh

# Expose ports:
# 3000 - MCP SSE server
# 5900 - VNC server (internal, used by noVNC)
# 6080 - noVNC web interface
EXPOSE 3000 5900 6080

ENTRYPOINT ["/entrypoint.sh"]
