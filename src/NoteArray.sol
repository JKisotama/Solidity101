// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract NotesArray {
    enum Status { Active, Archived }
    struct Note {
        uint256 id;
        string title;
        string content;
        Status status;
    }
    Note[] private notes;
    mapping(uint256 => uint256) private noteIndexById;

    event NoteCreated(uint256 indexed id, string title);
    event NoteUpdated(uint256 indexed id, string newTitle);
    event NoteArchived(uint256 indexed id);
    event NoteDeleted(uint256 indexed id);

    function createNote(string memory _title, string memory _content) public {
        uint256 id = notes.length;
        Note memory newNote = Note({id: id, title: _title, content: _content, status: Status.Active});
        notes.push(newNote);
        noteIndexById[id] = notes.length - 1;
        emit NoteCreated(id, _title);
    }

    function getNote(uint256 _id) public view returns (Note memory) {
        require(_id < notes.length, "Note does not exist");
        return notes[_id];
    }

    function updateNote(uint256 _id, string memory _newTitle, string memory _newContent) public {
        require(_id < notes.length, "Note does not exist");
        Note storage note = notes[_id];
        require(note.status == Status.Active, "Note is archived");
        note.title = _newTitle;
        note.content = _newContent;
        emit NoteUpdated(_id, _newTitle);
    }

    function archiveNote(uint256 _id) public {
        require(_id < notes.length, "Note does not exist");
        Note storage note = notes[_id];
        note.status = Status.Archived;
        emit NoteArchived(_id);
    }

    function deleteNote(uint256 _id) public {
        require(_id < notes.length, "Note does not exist");
        // Shift array elements to remove the note
        for (uint256 i = _id; i < notes.length - 1; i++) {
            notes[i] = notes[i + 1];
            notes[i].id = i;
        }
        notes.pop();
        emit NoteDeleted(_id);
    }

    function noteExists(uint256 _id) public view returns (bool) {
        return _id < notes.length;
    }

    function getAllNotes() public view returns (Note[] memory) {
        return notes;
    }
}
