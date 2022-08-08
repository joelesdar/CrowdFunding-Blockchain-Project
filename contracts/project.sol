// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {

    enum State {
        Opened,
        Closed
    }

    struct Project {
        string id;
        string name;
        string description;
        uint goal;
        address payable author;
        uint funds;
        State state;
    }

    struct Contribution {
        address contributor;
        uint value;
    }

    Project[] public projects;
    mapping(string => Contribution[]) public contributions;

    function createProject(string calldata _id, string calldata _name, string calldata _description, uint _goal) public {
        require(_goal > 0, 'fundraising goal must be greater than 0');
        Project memory project = Project(_id, _name, _description, _goal, payable(msg.sender), 0, State.Opened);
        projects.push(project);
        emit createProjectLog(_id, _name, _description, _goal);
    }

    function fundProject(uint projectIndex) public payable isNotAuthor(projectIndex) {
        Project memory project = projects[projectIndex];
        require(project.state != State.Closed, 'The funding of the project is closed');
        require(msg.value > 0, 'fundraising must be greater than 0');
        project.author.transfer(msg.value);
        project.funds += msg.value;
        contributions[project.id].push(Contribution(msg.sender, msg.value));
        projects[projectIndex] = project;
        emit fundProjectLog(projects[projectIndex].id, msg.value);
    }

    function changeProjectState(uint projectIndex, State newState) public isAuthor(projectIndex) {
        Project memory project = projects[projectIndex];
        require(project.state != newState, 'New state must be different');
        project.state = newState;
        projects[projectIndex] = project;
        emit changeProjectStateLog(projects[projectIndex].id, newState);
    }

    modifier isAuthor(uint projectIndex) {
        require(msg.sender == projects[projectIndex].author, 'Only author can change the state of the project');
        _;
    }

    modifier isNotAuthor(uint projectIndex) {
        require(msg.sender != projects[projectIndex].author, 'The author cannot fund the project');
        _;
    }

    event fundProjectLog(string projectId, uint newFunds);
    event changeProjectStateLog(string projectId, State newState);
    event createProjectLog(string projectId, string name, string description, uint goal);
}