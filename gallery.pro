TEMPLATE = subdirs
SUBDIRS = src \
          src/private \
            tests \
            doc

OTHER_FILES += rpm/*.spec
