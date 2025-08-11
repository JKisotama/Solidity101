// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Notes {
    enum Status { Active, Archived }
    struct Note {
        uint256 id;
        string title;
        string content;
        Status status;
    }
    uint256 private nextId;
    mapping(uint256 => Note) private notesById;
    mapping(uint256 => bool) private exists;

    event NoteCreated(uint256 indexed id, string title);
    event NoteUpdated(uint256 indexed id, string newTitle);
    event NoteArchived(uint256 indexed id);
    event NoteDeleted(uint256 indexed id);

    function createNote(string memory _title, string memory _content) public {
        notesById[nextId] = Note({id: nextId, title: _title, content: _content, status: Status.Active});
        exists[nextId] = true;
        emit NoteCreated(nextId, _title);
        nextId++;
    }

    function getNote(uint256 _id) public view returns (Note memory) {
        require(exists[_id], "Note does not exist");
        return notesById[_id];
    }

    function updateNote(uint256 _id, string memory _newTitle, string memory _newContent) public {
        require(exists[_id], "Note does not exist");
        Note storage note = notesById[_id];
        require(note.status == Status.Active, "Note is archived");
        note.title = _newTitle;
        note.content = _newContent;
        emit NoteUpdated(_id, _newTitle);
    }

    function archiveNote(uint256 _id) public {
        require(exists[_id], "Note does not exist");
        Note storage note = notesById[_id];
        note.status = Status.Archived;
        emit NoteArchived(_id);
    }

    function deleteNote(uint256 _id) public {
        require(exists[_id], "Note does not exist");
        delete notesById[_id];
        exists[_id] = false;
        emit NoteDeleted(_id);
    }

    function noteExists(uint256 _id) public view returns (bool) {
        return exists[_id];
    }
}
