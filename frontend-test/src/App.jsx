import React, { useState, useCallback, useMemo } from 'react';
import './App.css';

const MAX_SIZE = 100;
const MIN_SIZE = 1;

// Komponen Kotak (Square)
const Square = React.memo(({ r, c, isBlack, isKnight, isValidMove, onSquareClick }) => {
  let className = 'square';
  className += isBlack ? ' black' : ' white';
  
  if (isKnight) {
    className += ' knight-pos';
  } else if (isValidMove) {
    className += ' valid-move';
  } else {
    className += ' invalid-move';
  }

  const handleClick = () => {
    if (isValidMove) {
      onSquareClick(r, c);
    }
  };

  return (
    <div className={className} onClick={handleClick}>
      {isKnight && <span className="knight-icon">K</span>}
    </div>
  );
});

// Komponen Board (Papan)
const Board = React.memo(({ rows, cols, knightPos, onSquareClick }) => {
  const { r: kr, c: kc } = knightPos;
  
  const grid = useMemo(() => {
    const tempGrid = [];
    for (let r = 0; r < rows; r++) {
      const rowNodes = [];
      for (let c = 0; c < cols; c++) {
        const isBlack = (r + c) % 2 === 0;
        const isKnight = r === kr && c === kc;
        
        const dr = Math.abs(r - kr);
        const dc = Math.abs(c - kc);
        const isValidMove = (dr === 2 && dc === 1) || (dr === 1 && dc === 2);

        rowNodes.push(
          <Square 
            key={`${r}-${c}`}
            r={r}
            c={c}
            isBlack={isBlack}
            isKnight={isKnight}
            isValidMove={isValidMove}
            onSquareClick={onSquareClick}
          />
        );
      }
      tempGrid.push(<div key={`row-${r}`} className="board-row">{rowNodes}</div>);
    }
    return tempGrid;
  }, [rows, cols, kr, kc, onSquareClick]);

  return (
    <div className="board-container">
      <div className="board">
        {grid}
      </div>
    </div>
  );
});

// Utama (App)
function App() {
  const [rowInput, setRowInput] = useState(8);
  const [colInput, setColInput] = useState(8);
  
  const [boardConfig, setBoardConfig] = useState({ rows: 8, cols: 8 });
  const [knightPos, setKnightPos] = useState({ r: 0, c: 0 });

  const handleGenerate = () => {
    let r = parseInt(rowInput, 10);
    let c = parseInt(colInput, 10);
    if (isNaN(r) || r < MIN_SIZE) r = MIN_SIZE;
    if (r > MAX_SIZE) r = MAX_SIZE;
    if (isNaN(c) || c < MIN_SIZE) c = MIN_SIZE;
    if (c > MAX_SIZE) c = MAX_SIZE;
    
    setRowInput(r);
    setColInput(c);
    setBoardConfig({ rows: r, cols: c });
    setKnightPos({ r: 0, c: 0 });
  };

  const handleSquareClick = useCallback((r, c) => {
    setKnightPos({ r, c });
  }, []);

  return (
    <div className="app-container">
      <h1 className="title">Chess Lonely Knight</h1>
      
      <div className="controls">
        <div className="input-group">
          <label>Row</label>
          <input 
            type="number" 
            min={MIN_SIZE} 
            max={MAX_SIZE} 
            value={rowInput} 
            onChange={(e) => setRowInput(e.target.value)} 
          />
        </div>
        <div className="input-group">
          <label>Column</label>
          <input 
            type="number" 
            min={MIN_SIZE} 
            max={MAX_SIZE} 
            value={colInput} 
            onChange={(e) => setColInput(e.target.value)} 
          />
        </div>
        <button className="generate-btn" onClick={handleGenerate}>
          Generate<br/>Board
        </button>
      </div>

      <Board 
        rows={boardConfig.rows} 
        cols={boardConfig.cols} 
        knightPos={knightPos} 
        onSquareClick={handleSquareClick}
      />
    </div>
  );
}

export default App;
