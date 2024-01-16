function transcribe
	set -l filename $argv[1]
	set -l tmpdir (mktemp -d)

	# Convert the file into a .wav with a specific something
	ffmpeg -i $filename -ar 16000 $tmpdir/out.wav

	# Transcribe with whisper
	whisper-cpp \
		--model ~/Downloads/ggml-base.en.bin \
		--output-file $tmpdir/out \
		--output-json \
		--file $tmpdir/out.wav

	# Post Process
	cat $tmpdir/out.json


	rm $tmpdir/*
	rmdir $tmpdir
end
