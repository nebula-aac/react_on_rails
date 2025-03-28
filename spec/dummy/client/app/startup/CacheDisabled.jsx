import React from 'react';

export default class CacheDisabled extends React.Component {
  componentWillUnmount() {
    console.log('CacheDisabled#componentWillUnmount');
  }

  render() {
    return (
      <div className="container">
        <h2>Turbolinks cache is disabled</h2>
        <p>Must call componentWillUnmount.</p>
      </div>
    );
  }
}
