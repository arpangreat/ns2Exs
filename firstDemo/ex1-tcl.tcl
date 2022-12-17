Class mom
mom instproc greet {} {
	$self instvar age_
	puts "$age_ year mom say:
	 Whatsupp dude?"
}

Class kid -superclass mom
kid instproc greet {} {
	$self instvar age_
	puts "$age_ child say:
	 Yo Yo, Mom!!"
}

set a [new mom]
$a set age_ 42
set b [new kid]
$b set age_ 21

$a greet
$b greet
