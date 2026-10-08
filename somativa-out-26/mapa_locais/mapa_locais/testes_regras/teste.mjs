// Testa as regras de ../firestore.rules no emulador do Firestore.
// Requer Java e Firebase CLI. Uso: npm install && npm test
import { readFileSync } from 'node:fs';
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, addDoc, updateDoc, deleteDoc, collection } from 'firebase/firestore';

const env = await initializeTestEnvironment({
  projectId: 'mapa-locais-teste',
  firestore: { rules: readFileSync('firestore.rules', 'utf8'), host: '127.0.0.1', port: 8085 },
});

const valido = {
  nome: 'Academia Fitness', categoria: 'Academia', cidade: 'São Paulo',
  avaliacao: 4.8, distancia: 1.2, horario: '06:00 - 22:00', descricao: 'ok', favorito: false,
};

await env.withSecurityRulesDisabled(async (ctx) => {
  await setDoc(doc(ctx.firestore(), 'locais/existente'), valido);
});

const anonimo = env.authenticatedContext('uid-anonimo').firestore();
const semLogin = env.unauthenticatedContext().firestore();

const casos = [
  ['sem login NÃO lê', () => assertFails(getDoc(doc(semLogin, 'locais/existente')))],
  ['sem login NÃO cria', () => assertFails(addDoc(collection(semLogin, 'locais'), valido))],
  ['logado lê', () => assertSucceeds(getDoc(doc(anonimo, 'locais/existente')))],
  ['logado cria documento válido', () => assertSucceeds(addDoc(collection(anonimo, 'locais'), valido))],
  ['avaliação 7 é recusada', () => assertFails(addDoc(collection(anonimo, 'locais'), { ...valido, avaliacao: 7 }))],
  ['avaliação como texto é recusada', () => assertFails(addDoc(collection(anonimo, 'locais'), { ...valido, avaliacao: '4.8' }))],
  ['campo extra é recusado', () => assertFails(addDoc(collection(anonimo, 'locais'), { ...valido, admin: true }))],
  ['campo faltando é recusado', () => { const { descricao, ...sem } = valido; return assertFails(addDoc(collection(anonimo, 'locais'), sem)); }],
  ['nome vazio é recusado', () => assertFails(addDoc(collection(anonimo, 'locais'), { ...valido, nome: '' }))],
  ['favoritar (update parcial) funciona', () => assertSucceeds(updateDoc(doc(anonimo, 'locais/existente'), { favorito: true }))],
  ['editar com distância negativa é recusado', () => assertFails(updateDoc(doc(anonimo, 'locais/existente'), { distancia: -1 }))],
  ['outra coleção é bloqueada', () => assertFails(setDoc(doc(anonimo, 'usuarios/x'), { a: 1 }))],
  ['sem login NÃO exclui', () => assertFails(deleteDoc(doc(semLogin, 'locais/existente')))],
  ['logado exclui', () => assertSucceeds(deleteDoc(doc(anonimo, 'locais/existente')))],
];

let falhas = 0;
for (const [nome, fn] of casos) {
  try { await fn(); console.log('PASSOU  ' + nome); }
  catch (e) { falhas++; console.log('FALHOU  ' + nome + ' -> ' + e.message); }
}
await env.cleanup();
console.log(falhas === 0 ? `\n${casos.length}/${casos.length} regras OK` : `\n${falhas} falha(s)`);
process.exit(falhas ? 1 : 0);
