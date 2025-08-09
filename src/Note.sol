// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Notes {
    enum Status {
        Active,
        Archived
    }

    struct Note {
        uint256 id;
        string title;
        string content;
        Status status;
    }

    uint256 private nextId;
    Note[] private notes; 
    mapping(uint256 => Note) private notesById; 

    event NoteCreated(uint256 indexed id, string title);
    event NoteUpdated(uint256 indexed id, string newTitle);
    event NoteArchived(uint256 indexed id);

    function createNote(string memory _title, string memory _content) public {
        Note memory newNote = Note({
            id: nextId,
            title: _title,
            content: _content,
            status: Status.Active
        });

        notes.push(newNote);
        notesById[nextId] = newNote;

        emit NoteCreated(nextId, _title);
        nextId++;
    }

    function getNote(uint256 _id) public view returns (Note memory) {
        return notesById[_id];
    }

    function getAllNotes() public view returns (Note[] memory) {
        return notes;
    }

    function updateNote(uint256 _id, string memory _newTitle, string memory _newContent) public {
        Note storage note = notesById[_id];
        require(note.status == Status.Active, "Note is archived");
        note.title = _newTitle;
        note.content = _newContent;

        // Đồng bộ array
        for (uint256 i = 0; i < notes.length; i++) {
            if (notes[i].id == _id) {
                notes[i] = note;
                break;
            }
        }

        emit NoteUpdated(_id, _newTitle);
    }

    function archiveNote(uint256 _id) public {
        Note storage note = notesById[_id];
        note.status = Status.Archived;

        for (uint256 i = 0; i < notes.length; i++) {
            if (notes[i].id == _id) {
                notes[i] = note;
                break;
            }
        }

        emit NoteArchived(_id);
    }
}
