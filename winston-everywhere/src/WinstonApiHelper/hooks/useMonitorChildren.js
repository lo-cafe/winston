import { useState, useEffect } from 'react';

const useMonitorChildren = (query, transformer) => {
  const [state, setState] = useState({
    current: [],
    added: null,
    removed: null,
  });

  useEffect(() => {
    const element = document.querySelector(query);
    let currentNodes = [];
    let observer = null;

    function updateState(nodes, added, removed) {
      setState({
        current: nodes.map(node => transformer ? transformer(node) : node ),
        added: added ? (transformer ? transformer(added) : added) : null,
        removed: removed ? (transformer ? transformer(removed) : removed) : null,
      });
    }

    if (element) {
      currentNodes = Array.from(element.children);
      updateState(currentNodes);

      observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
          if (mutation.type === 'childList') {
            const added = mutation.addedNodes[0];
            const removed = mutation.removedNodes[0];

            if(added) currentNodes.push(added);
            if(removed) currentNodes = currentNodes.filter(node => node !== removed);

            updateState(currentNodes, added, removed);
          }
        });
      });
    }

    if (observer) {
      observer.observe(element, { childList: true });
    }

    return () => {
      if (observer) {
        observer.disconnect();
      }
    }
  }, [query, transformer]);

  return [state.current, state.added, state.removed];
}

export default useMonitorChildren;
