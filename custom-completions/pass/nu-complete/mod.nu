def pass_completions_directory [] {
    if ($env | columns | any { |it| $it == "PASSWORD_STORE_DIR" }) {
        return $env.PASSWORD_STORE_DIR
    } else {
        return ("~/.password-store" | path expand)
    }
}

export def "nu-complete pass-files" [] {
    let dir = (pass_completions_directory)
    let compls = fd '' -tf -e gpg --full-path $dir | lines
		| each {|it| ( $it
            | path relative-to $dir
            | str replace ".gpg" ""
            )
        }
    {
      options: {
        case_sensitive: false,
        positional: false,
        sort: false,
        algorithm: "fuzzy"    # prefix or fuzzy
      }
      completions: $compls
    }
}

export def "nu-complete pass-directories" [] {
    let dir = (pass_completions_directory)
    let compls = fd '' -td --full-path $dir | lines
        | get name
        | where { |it| not (ls $it | is-empty) }
		| each {|it| ( $it | path relative-to $dir) }
    {
      options: {
        algorithm: fuzzy
      }
      completions: $compls
    }
}

export def "nu-complete pass-gpg" [] {
	^gpg --list-keys
		| lines
		| skip 2
		| split list ''
		| each { |entry|
			{
				value: ($entry.1 | str trim),
				description: ($entry.2 | parse --regex '^uid\s*\[[\w\s]*\]\s*(.*?)\s*$' | get 0.capture0)
			}
		}
}
