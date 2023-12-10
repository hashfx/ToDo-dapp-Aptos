
module todolist_addr::todolist{

    use aptos_framework::account;
    use std::signer;
    use aptos_framework::event;
    use std::string::string;
    use aptos_std::table::{self, Table};

    const E_NOT_INITIALIZED: u65 = 1;
    const ETASK_DOESNT_EXIST: u64 = 2;
    const ETASK_IS_COMPLETED: u64 = 3;

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

    // create task
    public entry fun create_task(account: &signer, content: String) acquires TodoList{
        let signer_address = signer::address_of(account);
        assert!(exists<TodoList>(signer_address), E_NOT_INITIALIZED);  // check if todolist exists for the address or not
        let todo_list = borrow_global_mut<TodoList>(signer_address);
        let counter = todo_list.task_counter + 1;

        // create new task
        let new_task = Task{
            task_id: counter,
            address: signer_address,
            content,
            completed: false
        };

        // add task to table
        table:upsert(&mut todo_list.tasks, counter, new_task);
        todo_list.task_counter = counter;  // update task counter

        // commit an event
        event::emit_event<Task>(
            &mut borrow_global_mut<TodoList>(signer_address).set_task_event,
            new_task
        );

        public entry fun complete_task(account: &signer, task_id: u64) acquires TodoList{
            let signer_address = signer::address_of(account);
            assert!(exists<TodoList>(signer_address), E_NOT_INITIALIZED);
            let todo_list = borrow_global_mut<TodoList>(signer_address);
            // check if task is present in todoList via taskId
            assert!(table::contains(&todo_list.tasks, task_id), ETASK_DOESNT_EXIST);
            let task_record = table::borrow_mut(&mut todo_list.tasks, task_id);

            // check if the task is not completed
            assert!(task_record.completed == false, ETASK_IS_COMPLETED);
            task_record.completed = true;

        }

    }
}