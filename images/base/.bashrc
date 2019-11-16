export OLD_PATH=${PATH}

function switchTo9 {
    export JAVA_HOME=${JAVA_9_HOME}
    export JDK_HOME=${JAVA_HOME}
    echo "Switched to ${JAVA_HOME}"
    export PATH="${JAVA_HOME}/bin:${OLD_PATH:-}"
    java -version
}

function switchToGraal {
    export JAVA_HOME=${GRAALVM_HOME}
    export JDK_HOME=${JAVA_HOME}
    echo "Switched to ${JAVA_HOME}"
    export PATH="${JAVA_HOME}/bin:${OLD_PATH:-}"
    java -version
}

if [[ "${JDK_TO_USE:-}" = "GRAALVM" ]]; then
    JAVA_HOME=${GRAALVM_HOME}
else
	JAVA_HOME=${JAVA_9_HOME}
fi

export PATH="${JAVA_HOME}/bin:${OLD_PATH}"