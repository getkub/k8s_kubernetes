try:
    # Extract workflow vars
    workflow_variables = self.full_execution.get('workflow',{}).get("workflow_variables",[])
    def get_var_value(var_name, default):
        global workflow_variables
        for var in workflow_variables:
            if var['name'] == var_name:
                return var["value"]
        return default
    var_a = get_var_value("some_workflow_var", "default value")

    # Extract exec arguments
    extract_vars = json.loads(self.full_execution['execution_argument'])

    # Extract a node execution results
    try:
        for res in self.full_execution['results']:
            if res['action']['label'] == 'Node_name':
                node_result = json.loads(json.loads(res['result'])['message'])
                break
    except:
        pass

    # Print a json object in the format we want for the next nodes
    print(json.dumps({"test": var_a, "exec_vars": extract_vars, "node_result": node_result}))

except Exception as ex:
    import traceback
    print(f"Exception: {ex}")
    print(traceback.format_exc())
