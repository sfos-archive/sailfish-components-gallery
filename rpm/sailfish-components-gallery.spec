Name:       sailfish-components-gallery

Summary:    Sailfish Gallery UI Components
Version:    0.0.6
Release:    1
Group:      System/Libraries
License:    TBD
URL:        https://bitbucket.org/jolla/ui-sailfish-components-gallery
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  pkgconfig(QtCore) >= 4.8.0
BuildRequires:  pkgconfig(QtDeclarative)
BuildRequires:  pkgconfig(QtGui)
BuildRequires:  pkgconfig(QtOpenGL)

Requires:  sailfishsilica >= 0.8.22
Requires:  sailfish-components-contacts >= 0.0.11
Requires:  nemo-qml-plugins-thumbnailer

Obsoletes: sailfish-gallery <= 0.0.3
Provides:  sailfish-gallery > 0.0.3

%description
Sailfish Gallery UI Components

%package tests
Summary:    Unit tests for Sailfish Gallery UI components
Group:      System/Libraries
BuildRequires:  pkgconfig(QtTest)
Requires:   %{name} = %{version}-%{release}
Requires:   qtest-qml

%description tests
This package contains QML unit tests for Sailfish Gallery UI components

%package ts-devel
Summary:   Translation source for sailfish-components-gallery
License:   TBD
Group:     System/Libraries

%description ts-devel
Translation source for sailfish-components-gallery

%prep
%setup -q -n %{name}-%{version}

%build

%qmake

make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}

# Copy tests
mkdir -p %{buildroot}/opt/tests/sailfish-components-gallery/test-definition
mkdir -p %{buildroot}/opt/tests/sailfish-components-gallery/auto
cp -a tests/test-definition/tests.xml %{buildroot}/opt/tests/sailfish-components-gallery/test-definition
cp -a tests/auto/*qml %{buildroot}/opt/tests/sailfish-components-gallery/auto
cp -a tests/auto/*js %{buildroot}/opt/tests/sailfish-components-gallery/auto

%qmake_install

#
# Sailfish Gallery files
#
%files
%defattr(-,root,root,-)
%{_libdir}/qt4/imports/Sailfish/Gallery/*
%{_datadir}/translations/sailfish_components_gallery_eng_en.qm

%files tests
%defattr(-,root,root,-)
# >> files tests
/opt/tests/sailfish-components-gallery/*
# << files tests

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/sailfish_components_gallery.ts
