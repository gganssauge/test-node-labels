check:
	bash test-node-labels.sh

clean:
	git clean -d -x -f -e /.idea -e /.devcontainer/devcontainer.env

.PHONY:	check clean
