
"""Security boundary for the FCC Admin UI."""

import base64
import hmac
import os
from urllib.parse import urlsplit

from fastapi import HTTPException, Request


def _is_loopback(host: str | None) -> bool:
    if not host:
        return False
    host = host.strip().strip("[]").lower()
    return host in {"localhost", "127.0.0.1", "::1"}


def require_loopback_admin(request: Request) -> None:
    """Allow local access or authenticated same-origin HTTPS access."""
    client = request.client.host if request.client else None

    if _is_loopback(client):
        return

    password = os.environ.get("FCC_ADMIN_PASSWORD", "")
    authorization = request.headers.get("authorization", "")
    valid = False

    if password and authorization.startswith("Basic "):
        try:
            decoded = base64.b64decode(
                authorization[6:], validate=True
            ).decode("utf-8")
            username, supplied = decoded.split(":", 1)
            valid = (
                username == "maia"
                and hmac.compare_digest(supplied, password)
            )
        except (ValueError, UnicodeDecodeError):
            valid = False

    if not valid:
        raise HTTPException(
            status_code=401,
            detail="Authentication required",
            headers={"WWW-Authenticate": 'Basic realm="Maia Admin"'},
        )

    host = request.headers.get("host", "").split(":")[0].strip("[]").lower()
    origin = request.headers.get("origin")

    if origin:
        try:
            parsed = urlsplit(origin)
            if (
                parsed.scheme != "https"
                or parsed.hostname != host
                or parsed.username is not None
                or parsed.password is not None
            ):
                raise ValueError("Invalid origin")
        except ValueError:
            raise HTTPException(
                status_code=403, detail="Invalid admin origin"
            ) from None
