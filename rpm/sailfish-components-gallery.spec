Name:       sailfish-components-gallery-qt5

Summary:    Sailfish Gallery UI Components
Version:    1.2.8
Release:    1
License:    BSD
URL:        https://github.com/sailfishos/sailfish-components-gallery
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Gui)
BuildRequires:  pkgconfig(Qt5Concurrent)
BuildRequires:  qt5-qttools
BuildRequires:  qt5-qttools-linguist
BuildRequires:  pkgconfig(quillmetadata-qt5)
BuildRequires:  qt5-qttools-qthelp-devel
BuildRequires:  sailfish-qdoc-template

Requires:  sailfishsilica-qt5 >= 1.2.78
Requires:  nemo-qml-plugin-filemanager
Requires:  nemo-qml-plugin-thumbnailer-qt5
Requires:  libkeepalive >= 1.7.0
Requires:  sailfishshare-components
Requires:  sailfish-content-graphics >= 1.0.52
Requires:  qt5-qtdocgallery

%description
Sailfish Gallery UI Components

%package doc
Summary: Documentation for Sailfish Gallery UI components

%description doc
%{summary}.

%package tests
Summary:    Unit tests for Sailfish Gallery UI components
BuildRequires:  pkgconfig(Qt5Test)
Requires:   %{name} = %{version}-%{release}
Requires:   qt5-qtdeclarative-import-qttest
Requires:   qt5-qtdeclarative-devel-tools
Requires:   nemo-test-tools

%description tests
This package contains QML unit tests for Sailfish Gallery UI components

%package ts-devel
Summary:   Translation source for sailfish-components-gallery

%description ts-devel
Translation source for sailfish-components-gallery

%prep
%setup -q -n %{name}-%{version}

%build

%qmake5

make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}

# Copy tests
mkdir -p %{buildroot}/opt/tests/sailfish-components-gallery-qt5/test-definition
mkdir -p %{buildroot}/opt/tests/sailfish-components-gallery-qt5/auto
cp -a tests/test-definition/tests.xml %{buildroot}/opt/tests/sailfish-components-gallery-qt5/test-definition
cp -a tests/auto/*qml %{buildroot}/opt/tests/sailfish-components-gallery-qt5/auto
cp -a tests/auto/*js %{buildroot}/opt/tests/sailfish-components-gallery-qt5/auto

%qmake5_install

install -m 644 doc/html/*.html %{buildroot}/%{_docdir}/Sailfish/Gallery/
install -m 644 doc/sailfish-gallery.qch %{buildroot}/%{_docdir}/Sailfish/Gallery/
install -m 644 doc/html/sailfish-gallery.index %{buildroot}/%{_docdir}/Sailfish/Gallery/

#
# Sailfish Gallery files
#
%files
%defattr(-,root,root,-)
%license LICENSE.BSD
%{_libdir}/qt5/qml/Sailfish/Gallery/*
%{_datadir}/translations/sailfish_components_gallery_qt5_eng_en.qm

%files doc
%defattr(-,root,root,-)
%{_docdir}/Sailfish/Gallery/*

%files tests
%defattr(-,root,root,-)
# >> files tests
/opt/tests/sailfish-components-gallery-qt5/*
# << files tests

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/sailfish_components_gallery_qt5.ts
