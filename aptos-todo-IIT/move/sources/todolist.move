
module todolist_addr::todolist{

    use aptos_framework::account;
    use std::signer;
    use aptos_framework::event;
    use std::string::string;
    use aptos_std::table::{self, Table};

    struct TodoList has key {
        tasks: Table<u64, Task>,
        set_task_event: event::EventHandle<Task>,
        task_counter: u64
    }

    struct Task has store, drop, copy{
        task_id: u64,
        address: address,
        content: string,
        completed: bool,
    }

    public entry fun create_list(account: &signer){
        let todo_list = TodoList{
            tasks: table::new(),
            set_task_event: account::new_event_handle<Task>(account),
            task_counter: 0
        };
        move_to(account, todo_list);  // operates todoList for the mentioned account via frontend
    }
}