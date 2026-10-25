add:
	sh new-entry.sh

setup:
	@command -v pre-commit >/dev/null 2>&1 || { echo "pre-commit がありません。 pip install pre-commit"; exit 1; }
	pre-commit install
