This directory contains code that should only be implemented/used on the client side.

To centralize exception handling, ie, use a single assigned exception handler,
mark all methods with a safecall directive.
To support exception handling with "try ... except", surround the method call with
the exception handler, and do not mark the concerned method with a safe call directive.
