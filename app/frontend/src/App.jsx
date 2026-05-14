import React from 'react';
import { useState, useEffect } from 'react';

function App() {
    const [info, setInfo] = useState(null);

    useEffect(() => {
        fetch("/api/info")
        .then((data) => data.json())
        .then((data) => {
            setInfo(data);
        });
    }, []);

    return (
        <div className="App">
            {info && (
                <ul>
                    <li>Environment: {info.environment}</li>
                    <li>Instance ID: {info.instance_id}</li>
                    <li>Availability Zone: {info.availability_zone}</li>
                    <li>Region: {info.region}</li>
                </ul>
            )}
        </div>
    );
}

export default App;