function git-prepush
	if set -q argv[1]
		./bin/crlfmt -w $argv[1]
	end

	./dev generate bazel go
	./dev lint --short

	if set -q argv[1]
		./dev lint $argv[1]
		./dev test $argv[1]
	end
end
