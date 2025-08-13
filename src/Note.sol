// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Notes {
    address public owner;

    enum Status { Active, Archived }
    struct Note {
        uint256 id;
        string title;
        string content;
        Status status;
    }
    mapping(address => uint256) private nextId;
    mapping(address => mapping(uint256 => Note)) private notesByUser;
    mapping(address => mapping(uint256 => bool)) private exists;

    event NoteCreated(address indexed user, uint256 indexed id, string title);
    event NoteUpdated(address indexed user, uint256 indexed id, string newTitle);
    event NoteArchived(address indexed user, uint256 indexed id);
    event NoteDeleted(address indexed user, uint256 indexed id);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function createNote(string memory _title, string memory _content) public {
        uint256 id = nextId[msg.sender];
        notesByUser[msg.sender][id] = Note({id: id, title: _title, content: _content, status: Status.Active});
        exists[msg.sender][id] = true;
        emit NoteCreated(msg.sender, id, _title);
        nextId[msg.sender]++;
    }

    function getNote(address user, uint256 _id) public view returns (Note memory) {
        require(exists[user][_id], "Note does not exist");
        return notesByUser[user][_id];
    }

    function updateNote(uint256 _id, string memory _newTitle, string memory _newContent) public {
        require(exists[msg.sender][_id], "Note does not exist");
        Note storage note = notesByUser[msg.sender][_id];
        require(note.status == Status.Active, "Note is archived");
        note.title = _newTitle;
        note.content = _newContent;
        emit NoteUpdated(msg.sender, _id, _newTitle);
    }

    function archiveNote(uint256 _id) public {
        require(exists[msg.sender][_id], "Note does not exist");
        Note storage note = notesByUser[msg.sender][_id];
        note.status = Status.Archived;
        emit NoteArchived(msg.sender, _id);
    }

    function deleteNote(uint256 _id) public {
        require(exists[msg.sender][_id], "Note does not exist");
        delete notesByUser[msg.sender][_id];
        exists[msg.sender][_id] = false;
        emit NoteDeleted(msg.sender, _id);
    }

    function noteExists(address user, uint256 _id) public view returns (bool) {
        return exists[user][_id];
    }

    function nextNoteId(address user) public view returns (uint256) {
        return nextId[user];
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
