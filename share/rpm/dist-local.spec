Name: acps-<% $zilla->name %>
Version: <% (my $v = $zilla->version) =~ s/^\v//; $v %>
Release: 1
Summary: <% $zilla->abstract %>
License: <% $zilla->license->name %>
Group: Applications/CPAN
BuildArch: noarch
Vendor: <% $zilla->license->holder %>
Source: <% $archive %>
Requires: /usr/local/bin/perl
<%
  use List::MoreUtils qw( uniq );
  join "\n",
    map { "Requires: local-perl($_)" }
    uniq
    sort
    grep !/^perl$/,
    $zilla->prereqs->requirements_for('runtime', 'requires')->required_modules
%>
BuildRequires: /usr/local/bin/perl
<%
  use List::MoreUtils qw( uniq );
  join "\n",
    map { "BuildRequires: local-perl($_)" }
    uniq
    sort
    grep !/^perl$/,
    map { $zilla->prereqs->requirements_for($_, 'requires')->required_modules } qw( configure build test runtime )
%>
BuildRoot: %{_tmppath}/%{name}-%{version}-BUILD
%define acps_prefix /util
Prefix: %{acps_prefix}

%define _use_internal_dependency_generator 0
%define __find_requires %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)-filter-requires
%define __find_provides %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)-filter-provides

%description
<% $zilla->abstract %>

%prep
%setup -q -n <% $zilla->name %>-%{version}

# filter requires, sub local-perl for ^perl
cat << EOF > %{__find_requires}
#!/bin/sh

if [ -x /usr/lib/rpm/redhat/find-requires ] ; then
FINDREQ=/usr/lib/rpm/redhat/find-requires
else
FINDREQ=/usr/lib/rpm/find-requires
fi

\$FINDREQ \$* | perl -n -e 's/^perl/local-perl/; print unless $_ eq "local-perl >= 1:5.10"'
EOF
chmod +x %{__find_requires}

# filter provides, sub local-perl for ^perl
cat << EOF > %{__find_provides}
#!/bin/sh

if [ -x /usr/lib/rpm/redhat/find-provides ] ; then
FINDREQ=/usr/lib/rpm/redhat/find-provides
else
FINDREQ=/usr/lib/rpm/find-provides
fi

\$FINDREQ \$* | perl -n -e 's/^perl/local-perl/; print'
EOF
chmod +x %{__find_provides}

%build
if [ -e Build.PL ]; then
  perl Build.PL --install_path lib=%{acps_prefix}/lib/perl    \
                --install_path arch=%{acps_prefix}/lib/perl   \
                --install_path bin=%{acps_prefix}/bin         \
                --install_path script=%{acps_prefix}/bin      \
                --install_path script=%{acps_prefix}/bin      \
                --install_path bindoc=%{acps_prefix}/man/man1 \
                --install_path libdoc=%{acps_prefix}/man/man3 \
                --destdir %{buildroot}                       \
  && ./Build \
  && ./Build test
elif [ -e Makefile.PL ]; then
  perl Makefile.PL INSTALLSITELIB=%{acps_prefix}/lib/perl     \
                   INSTALLSITEARCH=%{acps_prefix}/lib/perl    \
                   INSTALLSITEBIN=%{acps_prefix}/bin          \
                   INSTALLSCRIPT=%{acps_prefix}/bin           \
                   INSTALLSITESCRIPT=%{acps_prefix}/bin       \
                   INSTALLSITEMAN1DIR=%{acps_prefix}/man/man1 \
                   INSTALLSITEMAN3DIR=%{acps_prefix}/man/man3 \
  && ./Build \
  && ./Build test
fi

%install
if [ "%{buildroot}" != "/" ]; then
  rm -rf %{buildroot}
fi

echo `ls`
if [ -e Build.PL ]; then
  ./Build install
elif [ -e Makefile.PL ]; then
  make install DESTDIR=%{buildroot}
fi
find %{buildroot} -not -type d | sed -e 's#%{buildroot}##' > %{_tmppath}/filelist

%clean
if [ "%{buildroot}" != "/" ] ; then
  rm -rf %{buildroot}
fi

%files -f %{_tmppath}/filelist
%defattr(-,root,root)
