from pathlib import Path

class Utilities:
    # property to get the relative path of files
    @property
    def files_path(self) -> Path:
        """Get the path to the shared files directory."""
        return Path(__file__).parent.parent.parent.resolve() / "api"

    def load_instructions(self, instructions_file: str) -> str:
        """Load instructions from a file."""
        file_path = self.files_path / instructions_file
        with file_path.open("r", encoding="utf-8", errors="ignore") as file:
            return file.read()