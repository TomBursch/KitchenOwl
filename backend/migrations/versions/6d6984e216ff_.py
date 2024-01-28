"""empty message

Revision ID: 6d6984e216ff
Revises: fffa4ab33d2a
Create Date: 2021-03-15 19:40:59.846065

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '6d6984e216ff'
down_revision = 'fffa4ab33d2a'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('association',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('antecedent_id', sa.Integer(), nullable=True),
    sa.Column('consequent_id', sa.Integer(), nullable=True),
    sa.Column('support', sa.Float(), nullable=True),
    sa.Column('confidence', sa.Float(), nullable=True),
    sa.Column('lift', sa.Float(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=False),
    sa.Column('updated_at', sa.DateTime(), nullable=False),
    sa.ForeignKeyConstraint(['antecedent_id'], ['item.id'], ),
    sa.ForeignKeyConstraint(['consequent_id'], ['item.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('history',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('shoppinglist_id', sa.Integer(), nullable=True),
    sa.Column('item_id', sa.Integer(), nullable=True),
    sa.Column('status', sa.Enum('ADDED', 'DROPPED', name='status'), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=False),
    sa.Column('updated_at', sa.DateTime(), nullable=False),
    sa.ForeignKeyConstraint(['item_id'], ['item.id'], ),
    sa.ForeignKeyConstraint(['shoppinglist_id'], ['shoppinglist.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.add_column('item', sa.Column('ordering', sa.Integer(), server_default='0', nullable=True))
    op.add_column('item', sa.Column('support', sa.Float(), server_default='0.0', nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('item', 'support')
    op.drop_column('item', 'ordering')
    op.drop_table('history')
    op.drop_table('association')
    # ### end Alembic commands ###
