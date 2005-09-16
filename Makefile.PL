use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Model::LDAP',
    AUTHOR    => 'Daniel Westermann-Clark',
    PREREQ_PM => {
        Catalyst  => 0,
        Net::LDAP => 0,
    },
    VERSION_FROM => 'lib/Catalyst/Model/LDAP.pm'
);


package MY;

sub postamble {
    return <<"...";
cover::
	cover -delete
	HARNESS_PERL_SWITCHES=-MDevel::Cover \$(MAKE) test
	cover

readme::
	perldoc -o text -d README \$(NAME)
...
}

1;
