_echo-black message:
    #!/usr/bin/env sh
    printf "\x1b[30m%s\x1b[0m\n" "{{message}}"

_echo-red message:
    #!/usr/bin/env sh
    printf "\x1b[31m%s\x1b[0m\n" "{{message}}"

_echo-green message:
    #!/usr/bin/env sh
    printf "\x1b[32m%s\x1b[0m\n" "{{message}}"

_echo-yellow message:
    #!/usr/bin/env sh
    printf "\x1b[33m%s\x1b[0m\n" "{{message}}"

_echo-blue message:
    #!/usr/bin/env sh
    printf "\x1b[34m%s\x1b[0m\n" "{{message}}"

_echo-magenta message:
    #!/usr/bin/env sh
    printf "\x1b[35m%s\x1b[0m\n" "{{message}}"

_echo-cyan message:
    #!/usr/bin/env sh
    printf "\x1b[36m%s\x1b[0m\n" "{{message}}"

_echo-white message:
    #!/usr/bin/env sh
    printf "\x1b[37m%s\x1b[0m\n" "{{message}}"

_echo-success message:
    @just _echo-green "✅ {{message}}"

_echo-error message:
    @just _echo-red "❌ {{message}}"

_echo-warning message:
    @just _echo-yellow "⚠️ {{message}}"

_echo-info message:
    @just _echo-cyan "{{message}}"
