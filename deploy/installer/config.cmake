if(WIN32)
    set(RootDir "@RootDir@")
    configure_file(
        ${CMAKE_CURRENT_LIST_DIR}/config/windows.xml.in
        ${CMAKE_BINARY_DIR}/installer/config/windows.xml
    )
elseif(APPLE AND NOT IOS)
    configure_file(
        ${CMAKE_CURRENT_LIST_DIR}/config/macos.xml.in
        ${CMAKE_BINARY_DIR}/installer/config/macos.xml
    )
elseif(LINUX)
    set(ApplicationsDir "@ApplicationsDir@")
    configure_file(
        ${CMAKE_CURRENT_LIST_DIR}/config/linux.xml.in
        ${CMAKE_BINARY_DIR}/installer/config/linux.xml
    )
    
    configure_file(
        ${CMAKE_CURRENT_LIST_DIR}/config/FRKN.desktop.in
        ${CMAKE_BINARY_DIR}/../AppDir/FRKN.desktop
    )
endif()

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/packages/org.frkn.package/meta/package.xml.in
    ${CMAKE_BINARY_DIR}/installer/packages/org.frkn.package/meta/package.xml
)
