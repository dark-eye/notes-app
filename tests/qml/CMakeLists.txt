find_program(QMLTESTRUNNER_BIN
    NAMES qmltestrunner
    PATHS /usr/lib/*/qt5/bin
    NO_DEFAULT_PATH
)

find_program(XVFB_RUN_BIN
    NAMES xvfb-run
)

set(QML_TST_FILES "")

macro(DECLARE_QML_TEST TST_NAME TST_QML_FILE)
    set(qmltest_command
        ${QMLTESTRUNNER_BIN} -import ${CMAKE_BINARY_DIR}/src/plugin -input ${CMAKE_CURRENT_SOURCE_DIR}/${TST_QML_FILE}
    )

    if(USE_XVFB)
        set(COMMAND_PREFIX ${XVFB_RUN_BIN} -a -s "-screen 0 1024x768x24")
        add_custom_target(xvfbTest${TST_NAME} ${COMMAND_PREFIX} ${qmltest_command})
    else()
        set(COMMAND_PREFIX "")
    endif()
    add_custom_target(test${TST_NAME} ${qmltest_command})

    add_test(NAME ${TST_NAME}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMAND ${COMMAND_PREFIX} ${qmltest_command}
    )

    set(QML_TST_FILES ${QML_TST_FILES} ${TST_QML_FILE})
endmacro()

if(QMLTESTRUNNER_BIN AND XVFB_RUN_BIN)

    # Add new tests here
    declare_qml_test("NotebooksDelegate" tst_NotebooksDelegate.qml)
    declare_qml_test("NotesPage" tst_NotesPage.qml)

else()
    if (NOT QMLTESTRUNNER_BIN)
        message(WARNING "Qml tests disabled: qmltestrunner not found")
    else()
        message(WARNING "Qml tests disabled: xvfb-run not found")
    endif()
endif()

add_custom_target(tst_QmlFiles ALL SOURCES ${QML_TST_FILES})
